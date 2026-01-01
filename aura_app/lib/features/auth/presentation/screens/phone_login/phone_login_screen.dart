import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/routes/app_routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/loading/ghost_running.dart';
import '../../../../../core/widgets/navigation/app_header.dart';
import '../../../../../core/widgets/buttons/primary_button.dart';
import '../../../../../core/widgets/inputs/phone_input_field.dart';
import '../../../../../core/ui/snackbar/app_snackbar.dart';
import '../../../../../core/ui/responsive/responsive.dart';
import '../../../data/datasources/auth_remote_datasource.dart';
import '../../../domain/usecases/otp_service.dart';
import '../../providers/phone_login_provider.dart';

class PhoneLoginScreen extends ConsumerStatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  ConsumerState<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends ConsumerState<PhoneLoginScreen>
    with TickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();

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

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();

    if (phone.isEmpty || phone.length != 10) {
      AppSnackbar.showError(
        context: context,
        message: "Please enter a valid 10-digit mobile number.",
      );
      return;
    }

    ref.read(phoneLoginProvider.notifier).setLoading(true);
    ref.read(phoneLoginProvider.notifier).updatePhoneNumber(phone);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const GhostRunning(
        primaryMessage: "Checking phone number…",
        secondaryMessage: "Hang tight!",
      ),
    );

    await FirebaseAuthService().sendOtp(
      phoneNumber: "+91$phone",
      forceResendToken: null,
      onCodeSent: (String verificationId, int? resendToken) {
        if (mounted) {
          Navigator.pop(context);
          ref.read(phoneLoginProvider.notifier).setLoading(false);

          OtpService.verificationId = verificationId;
          OtpService.resendToken = resendToken;
          OtpService.phoneNumber = "+91$phone";

          Navigator.pushNamed(context, AppRoutes.otp, arguments: "+91$phone");
        }
      },
      onError: (error) {
        if (mounted) {
          Navigator.pop(context);
          ref.read(phoneLoginProvider.notifier).setLoading(false);
          AppSnackbar.showError(context: context, message: error);
        }
      },
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
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
    final phoneLoginState = ref.watch(phoneLoginProvider);

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
                const AppHeader(title: "Phone Login", textColor: Colors.white),
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
                                          "assets/logos/Aura-logo.png",
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
                                  "Verify Your Number",
                                  style: TextStyle(
                                    color: Colors.white,
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
                                  "Enter your mobile number. We'll send you\nan OTP for secure login or registration.",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: subtitleSize,
                                    height: 1.4,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            SizedBox(height: responsive.h(3)),
                            PhoneInputField(
                              controller: _phoneController,
                              responsive: responsive,
                              slideAnimation: _inputSlide,
                              opacityAnimation: _inputOpacity,
                            ),
                            SizedBox(height: responsive.h(5)),
                            AnimatedBuilder(
                              animation: _buttonController,
                              builder: (context, _) {
                                return Opacity(
                                  opacity: _buttonOpacity.value,
                                  child: Transform.scale(
                                    scale: _buttonScale.value,
                                    child: phoneLoginState.isLoading
                                        ? const Center(
                                            child: CircularProgressIndicator(
                                              color: Colors.blueAccent,
                                            ),
                                          )
                                        : PrimaryButton(
                                            label: "Send OTP",
                                            onPressed: _sendOtp,
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
