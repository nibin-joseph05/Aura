import 'package:flutter/material.dart';

import '../../../../../core/constants/asset_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/ui/responsive/responsive.dart';
import '../../../../legal/presentation/screens/privacy_policy/privacy_policy.dart';
import '../phone_login/phone_login_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _titleController;
  late AnimationController _subtitleController;
  late AnimationController _buttonsController;
  late AnimationController _footerController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<Offset> _titleSlide;
  late Animation<double> _titleOpacity;
  late Animation<Offset> _subtitleSlide;
  late Animation<double> _subtitleOpacity;
  late Animation<double> _buttonScale;
  late Animation<double> _buttonOpacity;
  late Animation<double> _footerOpacity;

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
    _buttonsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _footerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );
    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeIn));

    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _titleController, curve: Curves.easeOutCubic),
        );
    _titleOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _titleController, curve: Curves.easeIn));

    _subtitleSlide =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _subtitleController,
            curve: Curves.easeOutCubic,
          ),
        );
    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _subtitleController, curve: Curves.easeIn),
    );

    _buttonScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _buttonsController, curve: Curves.easeOutBack),
    );
    _buttonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonsController, curve: Curves.easeIn),
    );

    _footerOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _footerController, curve: Curves.easeIn));
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
      if (mounted) _buttonsController.forward();
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) _footerController.forward();
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _titleController.dispose();
    _subtitleController.dispose();
    _buttonsController.dispose();
    _footerController.dispose();
    super.dispose();
  }

  void _signInWithGoogle() async {
    print('Google Sign In pressed');
    // TODO: Implement Google Sign In
  }

  void _signInWithPhone() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PhoneLoginScreen()),
    );
  }

  void _signInWithEmail() async {
    print('Email Sign In pressed');
    // TODO: Implement Email Sign In
  }

  void _navigateToPrivacyPolicy() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
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
          child: Padding(
            padding: responsive.horizontal(7),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildAnimatedLogo(responsive),
                SizedBox(height: responsive.h(3)),
                _buildAnimatedTitle(responsive),
                SizedBox(height: responsive.h(1.5)),
                _buildAnimatedSubtitle(responsive),
                SizedBox(height: responsive.h(5)),
                _buildAnimatedButtons(responsive),
                SizedBox(height: responsive.h(4)),
                _buildAnimatedFooter(responsive),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo(Responsive responsive) {
    final logoSize = responsive.isTablet
        ? responsive.w(20)
        : responsive.isLargeTablet
        ? responsive.w(15)
        : responsive.w(30);

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
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 3,
                  ),
                  BoxShadow(
                    color: Colors.cyan.withOpacity(0.2),
                    blurRadius: 40,
                    spreadRadius: 5,
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
                          colors: [Colors.blue.shade600, Colors.blue.shade800],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'AURA',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: logoSize * 0.2,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
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
          "Sign in to Aura",
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
        child: Text(
          "Choose how you'd like to continue",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white70,
            fontSize: subtitleSize,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedButtons(Responsive responsive) {
    return AnimatedBuilder(
      animation: _buttonsController,
      builder: (context, child) {
        return Opacity(
          opacity: _buttonOpacity.value,
          child: Transform.scale(
            scale: _buttonScale.value,
            child: Column(
              children: [
                _buildAuthButton(
                  responsive: responsive,
                  icon: Icons.phone_android_rounded,
                  text: "Continue with Phone",
                  backgroundColor: Colors.green.shade600,
                  onTap: _signInWithPhone,
                ),
                SizedBox(height: responsive.h(2)),
                _buildAuthButton(
                  responsive: responsive,
                  iconWidget: Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    child: Image.asset(
                      AssetConstants.googleLogo,
                      height: 24,
                      width: 24,
                      fit: BoxFit.contain,
                    ),
                  ),
                  text: "Continue with Google",
                  backgroundColor: Colors.white,
                  textColor: Colors.black87,
                  borderColor: Colors.grey.shade300,
                  onTap: _signInWithGoogle,
                ),
                SizedBox(height: responsive.h(2)),
                _buildAuthButton(
                  responsive: responsive,
                  icon: Icons.email_rounded,
                  text: "Continue with Email",
                  backgroundColor: Colors.blueAccent,
                  onTap: _signInWithEmail,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedFooter(Responsive responsive) {
    final footerSize = responsive.isLargeTablet
        ? 16.0
        : responsive.isTablet
        ? 14.0
        : 12.0;

    return FadeTransition(
      opacity: _footerOpacity,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: responsive.isTablet ? responsive.w(10) : responsive.w(5),
        ),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              color: Colors.white54,
              fontSize: footerSize,
              height: 1.4,
            ),
            children: [
              const TextSpan(
                text: "By continuing, you agree to our Terms of Service and ",
              ),
              WidgetSpan(
                child: GestureDetector(
                  onTap: _navigateToPrivacyPolicy,
                  child: Text(
                    "Privacy Policy",
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: footerSize,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthButton({
    required Responsive responsive,
    IconData? icon,
    Widget? iconWidget,
    required String text,
    required Color backgroundColor,
    Color textColor = Colors.white,
    Color? borderColor,
    required VoidCallback onTap,
  }) {
    final buttonFontSize = responsive.isLargeTablet
        ? 22.0
        : responsive.isTablet
        ? 19.0
        : 16.0;

    final buttonPadding = responsive.isLargeTablet
        ? 20.0
        : responsive.isTablet
        ? 18.0
        : 16.0;

    final iconSize = responsive.isLargeTablet
        ? 28.0
        : responsive.isTablet
        ? 26.0
        : 24.0;

    return SizedBox(
      width: double.infinity,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(
          responsive.radius(AppDimensions.radiusXL),
        ),
        elevation: AppDimensions.elevationM,
        shadowColor: Colors.black.withOpacity(0.3),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            responsive.radius(AppDimensions.radiusXL),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: buttonPadding,
              horizontal: responsive.w(5),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                responsive.radius(AppDimensions.radiusXL),
              ),
              border: borderColor != null
                  ? Border.all(color: borderColor, width: 1)
                  : null,
              gradient: borderColor == null
                  ? LinearGradient(
                      colors: [
                        backgroundColor,
                        Color.lerp(backgroundColor, Colors.black, 0.1)!,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: iconSize + 8,
                  height: iconSize + 8,
                  alignment: Alignment.center,
                  child:
                      iconWidget ??
                      Icon(
                        icon,
                        color: textColor == Colors.white
                            ? Colors.white
                            : Colors.black87,
                        size: iconSize,
                      ),
                ),
                SizedBox(width: responsive.w(3)),
                Text(
                  text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: buttonFontSize,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
