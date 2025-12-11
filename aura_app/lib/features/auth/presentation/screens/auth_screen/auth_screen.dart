import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../phone_login/phone_login_screen.dart';
import '../privacy_policy/privacy_policy.dart';

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

    _startAnimations();
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
  }

  void _signInWithPhone() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PhoneLoginScreen()),
    );
  }

  void _signInWithEmail() async {
    print('Email Sign In pressed');
  }

  void _navigateToPrivacyPolicy() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A1A2F), Color(0xFF134B73)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _logoOpacity.value,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: Container(
                          width: 120,
                          height: 120,
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
                              'assets/logos/Aura-logo.png',
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
                                  child: const Center(
                                    child: Text(
                                      'AURA',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
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
                ),

                const SizedBox(height: 40),

                SlideTransition(
                  position: _titleSlide,
                  child: FadeTransition(
                    opacity: _titleOpacity,
                    child: const Text(
                      "Sign in to Aura",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                SlideTransition(
                  position: _subtitleSlide,
                  child: FadeTransition(
                    opacity: _subtitleOpacity,
                    child: const Text(
                      "Choose how you'd like to continue",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 50),

                AnimatedBuilder(
                  animation: _buttonsController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _buttonOpacity.value,
                      child: Transform.scale(
                        scale: _buttonScale.value,
                        child: Column(
                          children: [
                            _authButton(
                              icon: Icons.phone_android_rounded,
                              text: "Continue with Phone",
                              backgroundColor: Colors.green.shade600,
                              onTap: _signInWithPhone,
                            ),
                            const SizedBox(height: 16),

                            _authButton(
                              iconWidget: Container(
                                width: 24,
                                height: 24,
                                alignment: Alignment.center,
                                child: Image.asset(
                                  'assets/icons/google/google-logo.webp',
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
                            const SizedBox(height: 16),

                            _authButton(
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
                ),

                const SizedBox(height: 40),

                FadeTransition(
                  opacity: _footerOpacity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          height: 1.4,
                        ),
                        children: [
                          const TextSpan(
                            text:
                                "By continuing, you agree to our Terms of Service and ",
                          ),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: _navigateToPrivacyPolicy,
                              child: const Text(
                                "Privacy Policy",
                                style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontSize: 12,
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _authButton({
    IconData? icon,
    Widget? iconWidget,
    required String text,
    required Color backgroundColor,
    Color textColor = Colors.white,
    Color? borderColor,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
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
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  child:
                      iconWidget ??
                      Icon(
                        icon,
                        color: textColor == Colors.white
                            ? Colors.white
                            : Colors.black87,
                        size: 24,
                      ),
                ),
                const SizedBox(width: 12),
                Text(
                  text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
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
