import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../../../../../core/routes/app_routes.dart';
import '../../../../../core/widgets/buttons/primary_button.dart';
import '../../../../../core/widgets/loading/ghost_running.dart';
import '../../../../../core/widgets/navigation/app_header.dart';
import '../../../../../core/widgets/inputs/otp_input_field.dart';
import '../../../../../core/widgets/buttons/resend_otp_timer.dart';
import '../../../../../core/ui/snackbar/app_snackbar.dart';
import '../../../../../core/ui/responsive/responsive.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/constants/asset_constants.dart';
import '../../../data/datasources/firebase_auth_datasource.dart';
import '../../../domain/models/auth_success_payload.dart';
import '../../providers/otp_state_provider.dart';
import '../../providers/otp_provider.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phoneNumber;

  const OtpScreen({super.key, required this.phoneNumber});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen>
    with TickerProviderStateMixin {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  late AnimationController _logoController;
  late AnimationController _contentController;
  late AnimationController _buttonController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<Offset> _contentSlide;
  late Animation<double> _contentOpacity;
  late Animation<double> _buttonScale;
  late Animation<double> _buttonOpacity;

  StreamSubscription? _smsSubscription;
  Timer? _resendTimer;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _setupSmsAutoFill();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _startResendTimer();
    });
  }

  void _initAnimations() {
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _contentController = AnimationController(
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

    _contentSlide =
        Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _contentController,
            curve: Curves.easeOutCubic,
          ),
        );
    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeIn),
    );

    _buttonScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeOutBack),
    );
    _buttonOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _buttonController, curve: Curves.easeIn));

    _startAnimations();
  }

  void _startAnimations() {
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _contentController.forward();
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _buttonController.forward();
    });
  }

  void _setupSmsAutoFill() async {
    await SmsAutoFill().listenForCode();
    _smsSubscription = SmsAutoFill().code.listen((code) {
      if (_hasNavigated || !mounted) return;

      final digits = code.replaceAll(RegExp(r'[^0-9]'), '');
      if (digits.length == 6) {
        ref.read(otpProvider.notifier).setAutoFillOtp(digits);

        for (int i = 0; i < 6; i++) {
          _controllers[i].text = digits[i];
        }

        _verifyOtp();
      }
    });
  }

  void _startResendTimer() {
    ref.read(otpProvider.notifier).resetTimer();
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final current = ref.read(otpProvider).timerSeconds;
      if (current <= 1) {
        timer.cancel();
        ref.read(otpProvider.notifier).setTimerSeconds(0);
        ref.read(otpProvider.notifier).setResendActive(true);
      } else {
        ref.read(otpProvider.notifier).setTimerSeconds(current - 1);
      }
    });
  }

  void _handleOtpChange(int index, String value) {
    ref.read(otpProvider.notifier).updateDigit(index, value);

    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        final otpState = ref.read(otpProvider);
        if (otpState.isComplete && !otpState.isVerifying) {
          _verifyOtp();
        }
      }
    } else {
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  Future<void> _verifyOtp() async {
    if (_hasNavigated) return;

    final otpState = ref.read(otpProvider);

    if (!otpState.isComplete || otpState.isVerifying) return;

    ref.read(otpProvider.notifier).setVerifying(true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const GhostRunning(
        primaryMessage: "Verifying your OTP...",
        secondaryMessage: "Please wait",
      ),
    );

    try {
      final otpStoredState = ref.read(otpStateProvider);
      final user = await FirebaseAuthDataSource().verifyOtp(
        verificationId: otpStoredState.verificationId!,
        otp: otpState.fullOtp,
      );

      if (!mounted) return;
      Navigator.pop(context);

      if (user == null) {
        ref.read(otpProvider.notifier).setVerifying(false);
        ref.read(otpProvider.notifier).clearOtp();
        for (var c in _controllers) {
          c.clear();
        }
        _focusNodes.first.requestFocus();
        return;
      }

      _hasNavigated = true;

      _smsSubscription?.cancel();
      _resendTimer?.cancel();
      ref.invalidate(otpProvider);
      ref.invalidate(otpStateProvider);

      Navigator.pushReplacementNamed(
        context,
        AppRoutes.otpSuccess,
        arguments: AuthSuccessPayload(
          method: AuthMethod.phone,
          identifier: widget.phoneNumber,
          isNewUser: true,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ref.read(otpProvider.notifier).setVerifying(false);

      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      ref.read(otpProvider.notifier).setError(errorMsg);
      AppSnackbar.showError(context: context, message: errorMsg);

      ref.read(otpProvider.notifier).clearOtp();
      for (var c in _controllers) {
        c.clear();
      }
      _focusNodes.first.requestFocus();
    }
  }

  Future<void> _resendOtp() async {
    final otpState = ref.read(otpProvider);
    if (!otpState.canResend) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const GhostRunning(
        primaryMessage: "Sending new OTP...",
        secondaryMessage: "Just a moment",
      ),
    );

    await FirebaseAuthDataSource().sendOtp(
      phoneNumber: widget.phoneNumber,
      forceResendToken: ref.read(otpStateProvider).resendToken,
      onAutoVerified: (PhoneAuthCredential credential) async {
        try {
          final result = await FirebaseAuth.instance.signInWithCredential(
            credential,
          );
          if (!mounted) return;
          Navigator.pop(context);
          if (result.user != null && !_hasNavigated) {
            _hasNavigated = true;
            _smsSubscription?.cancel();
            _resendTimer?.cancel();
            ref.invalidate(otpProvider);
            ref.invalidate(otpStateProvider);
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.otpSuccess,
              arguments: AuthSuccessPayload(
                method: AuthMethod.phone,
                identifier: widget.phoneNumber,
                isNewUser: true,
              ),
            );
          }
        } catch (_) {
          if (mounted) Navigator.pop(context);
        }
      },
      onCodeSent: (verificationId, resendToken) {
        if (!mounted) return;
        Navigator.pop(context);
        ref
            .read(otpStateProvider.notifier)
            .setVerificationData(
              verificationId: verificationId,
              resendToken: resendToken,
            );
        _startResendTimer();
        AppSnackbar.showSuccess(
          context: context,
          message: "A new OTP has been sent to your number",
        );
      },
      onError: (error) {
        if (!mounted) return;
        Navigator.pop(context);
        AppSnackbar.showError(context: context, message: error);
      },
    );
  }

  @override
  void dispose() {
    _hasNavigated = true;
    _smsSubscription?.cancel();
    _resendTimer?.cancel();
    SmsAutoFill().unregisterListener();

    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }

    _logoController.dispose();
    _contentController.dispose();
    _buttonController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final otpState = ref.watch(otpProvider);

    final titleSize = responsive.isLargeTablet
        ? 30.0
        : responsive.isTablet
        ? 28.0
        : 26.0;

    final subtitleSize = responsive.isLargeTablet
        ? 17.0
        : responsive.isTablet
        ? 16.0
        : 15.0;

    final phoneSize = responsive.isLargeTablet
        ? 18.0
        : responsive.isTablet
        ? 17.0
        : 16.0;

    final noteSize = responsive.isLargeTablet
        ? 14.0
        : responsive.isTablet
        ? 13.0
        : 12.0;

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
        child: SafeArea(
          child: Column(
            children: [
              AppHeader(title: "Verify OTP", textColor: Colors.white),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: responsive.w(6),
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
                                    width: responsive.isTablet ? 140.0 : 120.0,
                                    height: responsive.isTablet ? 140.0 : 120.0,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.4,
                                          ),
                                          blurRadius: 25,
                                          spreadRadius: 4,
                                        ),
                                        BoxShadow(
                                          color: AppColors.accent.withValues(
                                            alpha: 0.25,
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
                          SizedBox(
                            height: responsive.space(AppDimensions.marginL),
                          ),
                          SlideTransition(
                            position: _contentSlide,
                            child: FadeTransition(
                              opacity: _contentOpacity,
                              child: Column(
                                children: [
                                  Text(
                                    "Enter the OTP",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: titleSize,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(
                                    height: responsive.space(
                                      AppDimensions.marginS,
                                    ),
                                  ),
                                  Text(
                                    "We've sent a 6-digit code to",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: subtitleSize,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: responsive.space(4)),
                                  Text(
                                    widget.phoneNumber,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: phoneSize,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: responsive.space(6)),
                                  Text(
                                    "If this number is incorrect, go back and edit it",
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: noteSize,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: responsive.space(AppDimensions.marginL),
                          ),
                          SlideTransition(
                            position: _contentSlide,
                            child: FadeTransition(
                              opacity: _contentOpacity,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: List.generate(
                                      6,
                                      (i) => OtpInputField(
                                        controller: _controllers[i],
                                        focusNode: _focusNodes[i],
                                        index: i,
                                        onChanged: (value) =>
                                            _handleOtpChange(i, value),
                                        responsive: responsive,
                                        hasError: otpState.hasError,
                                      ),
                                    ),
                                  ),
                                  if (otpState.hasError &&
                                      otpState.errorMessage != null) ...[
                                    SizedBox(height: responsive.h(1)),
                                    Text(
                                      otpState.errorMessage!,
                                      style: const TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: responsive.space(AppDimensions.marginL),
                          ),
                          ResendOtpTimer(
                            timerSeconds: otpState.timerSeconds,
                            canResend: otpState.canResend,
                            onResend: _resendOtp,
                          ),
                          SizedBox(
                            height: responsive.space(AppDimensions.marginXL),
                          ),
                          AnimatedBuilder(
                            animation: _buttonController,
                            builder: (context, _) {
                              return Opacity(
                                opacity: _buttonOpacity.value,
                                child: Transform.scale(
                                  scale: _buttonScale.value,
                                  child: otpState.isVerifying
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : PrimaryButton(
                                          label: "Verify",
                                          onPressed: _verifyOtp,
                                          responsive: responsive,
                                        ),
                                ),
                              );
                            },
                          ),

                          SizedBox(
                            height: responsive.space(AppDimensions.marginL),
                          ),
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
    );
  }
}
