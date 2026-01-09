import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/routes/app_routes.dart';
import '../../../../../core/widgets/inputs/app_text_field.dart';
import '../../../../../core/widgets/loading/ghost_running.dart';
import '../../../../../core/widgets/navigation/app_header.dart';
import '../../../../../core/widgets/buttons/primary_button.dart';
import '../../../../../core/ui/snackbar/app_snackbar.dart';
import '../../../../../core/ui/responsive/responsive.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/constants/asset_constants.dart';
import '../../../data/datasources/firebase_auth_datasource.dart';
import '../../../domain/models/auth_success_payload.dart';
import '../../providers/email_login_provider.dart';

class EmailLoginScreen extends ConsumerStatefulWidget {
  const EmailLoginScreen({super.key});

  @override
  ConsumerState<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends ConsumerState<EmailLoginScreen>
    with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late AnimationController _logoController;
  late AnimationController _titleController;
  late AnimationController _subtitleController;
  late AnimationController _inputController;
  late AnimationController _buttonController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<Offset> _titleSlide;
  late Animation<double> _titleOpacity;
  late Animation<Offset> _subtitleSlide;
  late Animation<double> _subtitleOpacity;
  late Animation<Offset> _inputSlide;
  late Animation<double> _inputOpacity;
  late Animation<double> _buttonScale;
  late Animation<double> _buttonOpacity;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimation();
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
    _inputController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _logoScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );
    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeIn));

    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _titleController, curve: Curves.easeOutCubic),
        );
    _titleOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _titleController, curve: Curves.easeIn));

    _subtitleSlide =
        Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _subtitleController,
            curve: Curves.easeOutCubic,
          ),
        );
    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _subtitleController, curve: Curves.easeIn),
    );

    _inputSlide = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _inputController, curve: Curves.easeOutCubic),
        );
    _inputOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _inputController, curve: Curves.easeIn));

    _buttonScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeOutBack),
    );
    _buttonOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _buttonController, curve: Curves.easeIn));
  }

  void _startAnimation() {
    _logoController.forward();

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _titleController.forward();
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _subtitleController.forward();
    });

    Future.delayed(const Duration(milliseconds: 450), () {
      if (mounted) _inputController.forward();
    });

    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) _buttonController.forward();
    });
  }

  bool _validateInputs() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      AppSnackbar.showError(
        context: context,
        message: "Please enter your email address",
      );
      return false;
    }

    if (!email.contains('@') || !email.contains('.')) {
      AppSnackbar.showError(
        context: context,
        message: "Please enter a valid email address",
      );
      return false;
    }

    if (password.isEmpty) {
      AppSnackbar.showError(
        context: context,
        message: "Please enter your password",
      );
      return false;
    }

    return true;
  }

  Future<void> _handleAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final notifier = ref.read(emailLoginProvider.notifier);

    notifier.clearErrors();

    final isValid = notifier.validateFields(
      email: email,
      password: password,
      context: context,
    );

    if (!isValid) return;

    notifier.setLoading(true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const GhostRunning(
        primaryMessage: "Signing you in...",
        secondaryMessage: "Please wait",
      ),
    );

    try {
      await FirebaseAuthDataSource().signInWithEmailPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;
      Navigator.pop(context);

      notifier.setLoading(false);

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.otpSuccess,
        (_) => false,
        arguments: AuthSuccessPayload(
          method: AuthMethod.email,
          identifier: email,
          isNewUser: true,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      notifier.setLoading(false);

      AppSnackbar.showError(
        context: context,
        message: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _logoController.dispose();
    _titleController.dispose();
    _subtitleController.dispose();
    _inputController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final emailState = ref.watch(emailLoginProvider);

    final titleSize = responsive.isLargeTablet
        ? 32.0
        : responsive.isTablet
        ? 28.0
        : 26.0;

    final subtitleSize = responsive.isLargeTablet
        ? 18.0
        : responsive.isTablet
        ? 16.0
        : 15.0;

    final logoSize = responsive.isLargeTablet
        ? 160.0
        : responsive.isTablet
        ? 140.0
        : 120.0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.primaryGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
            child: Column(
              children: [
                const AppHeader(
                  title: "Email Login",
                  textColor: AppColors.textLight,
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: responsive.w(7),
                        ),
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
                                      width: logoSize,
                                      height: logoSize,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primary
                                                .withOpacity(0.4),
                                            blurRadius: 25,
                                            spreadRadius: 4,
                                          ),
                                          BoxShadow(
                                            color: AppColors.accent.withOpacity(
                                              0.25,
                                            ),
                                            blurRadius: 40,
                                            spreadRadius: 6,
                                          ),
                                        ],
                                      ),
                                      child: ClipOval(
                                        child: Image.asset(
                                          AssetConstants.auraLogo,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: responsive.h(4)),

                            SlideTransition(
                              position: _titleSlide,
                              child: FadeTransition(
                                opacity: _titleOpacity,
                                child: Text(
                                  "Sign in with Email",
                                  style: TextStyle(
                                    color: AppColors.textLight,
                                    fontSize: titleSize,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),

                            SizedBox(height: responsive.h(1.2)),

                            SlideTransition(
                              position: _subtitleSlide,
                              child: FadeTransition(
                                opacity: _subtitleOpacity,
                                child: Text(
                                  "Use the email linked to your Google or Phone login",
                                  style: TextStyle(
                                    color: AppColors.textLight.withOpacity(
                                      0.75,
                                    ),
                                    fontSize: subtitleSize,
                                    height: 1.4,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),

                            SizedBox(height: responsive.h(3)),
                            SlideTransition(
                              position: _inputSlide,
                              child: FadeTransition(
                                opacity: _inputOpacity,
                                child: Column(
                                  children: [
                                    AppTextField(
                                      controller: _emailController,
                                      responsive: responsive,
                                      hint: "Email",
                                      icon: Icons.email_outlined,
                                      keyboardType: TextInputType.emailAddress,
                                      errorText: emailState.emailError,
                                    ),

                                    SizedBox(height: responsive.h(2)),

                                    AppTextField(
                                      controller: _passwordController,
                                      responsive: responsive,
                                      hint: "Password",
                                      icon: Icons.lock_outline,
                                      obscureText: emailState.obscurePassword,
                                      errorText: emailState.passwordError,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          emailState.obscurePassword
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          color: AppColors.textLight
                                              .withOpacity(0.7),
                                        ),
                                        onPressed: () {
                                          ref
                                              .read(emailLoginProvider.notifier)
                                              .togglePasswordVisibility();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: responsive.h(4)),

                            AnimatedBuilder(
                              animation: _buttonController,
                              builder: (context, _) {
                                return Opacity(
                                  opacity: _buttonOpacity.value,
                                  child: Transform.scale(
                                    scale: _buttonScale.value,
                                    child: emailState.isLoading
                                        ? const CircularProgressIndicator(
                                            color: AppColors.primary,
                                          )
                                        : PrimaryButton(
                                            label: "Sign In",
                                            onPressed: _handleAuth,
                                            responsive: responsive,
                                          ),
                                  ),
                                );
                              },
                            ),

                            SizedBox(height: responsive.h(3)),
                          ],
                        ),
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
}
