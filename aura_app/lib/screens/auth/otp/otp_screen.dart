import 'dart:async';
import 'package:flutter/material.dart';
import '../../../components/loading/ghost_running.dart';
import '../../../services/auth/firebase_auth_service.dart';
import '../../../services/auth/otp_service.dart';
import 'package:sms_autofill/sms_autofill.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpScreen({super.key, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with TickerProviderStateMixin {
  final List<TextEditingController> _controllers =
  List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes =
  List.generate(6, (index) => FocusNode());

  String? _errorMessage;
  bool _isVerifying = false;
  int _timerSeconds = 60;
  Timer? _timer;

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
    SmsAutoFill().listenForCode();

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
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );

    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeOutCubic),
    );
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeIn),
    );

    _subtitleSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _subtitleController, curve: Curves.easeOutCubic),
    );
    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _subtitleController, curve: Curves.easeIn),
    );

    _inputSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _inputController, curve: Curves.easeOutCubic),
    );
    _inputOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _inputController, curve: Curves.easeIn),
    );

    _buttonScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeOutBack),
    );
    _buttonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeIn),
    );

    _startAnimations();
    _startTimer();
  }

  void _startAnimations() {
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 150), () {
      _titleController.forward();
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      _subtitleController.forward();
    });
    Future.delayed(const Duration(milliseconds: 450), () {
      _inputController.forward();
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      _buttonController.forward();
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timerSeconds = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_timerSeconds == 0) {
        timer.cancel();
      } else {
        setState(() {
          _timerSeconds--;
        });
      }
    });
  }

  String _getOtp() {
    return _controllers.map((c) => c.text).join();
  }

  Future<void> _verifyOtp() async {
    final otp = _getOtp();

    if (otp.length != 6 || _controllers.any((c) => c.text.isEmpty)) {
      _showError("Please enter the complete 6-digit OTP.");
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });


    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const GhostRunning(),
    );

    try {
      final user = await FirebaseAuthService().verifyOtp(
        verificationId: OtpService.verificationId!,
        otp: otp,
      );

      Navigator.pop(context);

      if (user == null) {
        _showError("Invalid or expired OTP. Please try again.");
        setState(() => _isVerifying = false);
        return;
      }

      setState(() => _isVerifying = false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const _OtpSuccessScreen(),
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      _showError("Unable to verify OTP. Please check your connection and try again.");
      setState(() => _isVerifying = false);
    }
  }

  Future<void> _resendOtp() async {
    if (_timerSeconds != 0) return;

    setState(() {
      _errorMessage = null;
    });
    _startTimer();


    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const GhostRunning(),
    );

    await FirebaseAuthService().sendOtp(
      phoneNumber: widget.phoneNumber,
      forceResendToken: OtpService.resendToken,
      onCodeSent: (verificationId, resendToken) {
        Navigator.pop(context);
        OtpService.verificationId = verificationId;
        OtpService.resendToken = resendToken;

        setState(() {
          _errorMessage = "A new OTP has been sent to your number.";
        });
      },
      onError: (error) {
        Navigator.pop(context);
        _showError(error);
      },
    );
  }

  void _showError(String msg) {
    setState(() => _errorMessage = msg);
  }

  Widget _otpBox(int index) {
    return SizedBox(
      width: 50,
      height: 60,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        cursorColor: Colors.white,
        style: const TextStyle(fontSize: 22, color: Colors.white),
        decoration: InputDecoration(
          counterText: "",
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blueAccent),
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            if (index < 5) {
              _focusNodes[index + 1].requestFocus();
            } else {
              _focusNodes[index].unfocus();

              final otp = _getOtp();
              if (otp.length == 6 && !_isVerifying) {
                _verifyOtp();
              }
            }
          } else {
            if (index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _logoController.dispose();
    _titleController.dispose();
    _subtitleController.dispose();
    _inputController.dispose();
    _buttonController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A2F),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),


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
                                  color: Colors.blue.shade400.withOpacity(0.4),
                                  blurRadius: 25,
                                  spreadRadius: 4,
                                ),
                                BoxShadow(
                                  color: Colors.cyan.shade300.withOpacity(0.2),
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

                  const SizedBox(height: 30),


                  SlideTransition(
                    position: _titleSlide,
                    child: FadeTransition(
                      opacity: _titleOpacity,
                      child: const Text(
                        "Enter the OTP",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),


                  SlideTransition(
                    position: _subtitleSlide,
                    child: FadeTransition(
                      opacity: _subtitleOpacity,
                      child: Column(
                        children: [
                          const Text(
                            "We’ve sent a 6-digit code to",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.phoneNumber,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "If this number is incorrect, go back and edit it.",
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),


                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 14),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.redAccent),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.redAccent),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),


                  SlideTransition(
                    position: _inputSlide,
                    child: FadeTransition(
                      opacity: _inputOpacity,
                      child: PinFieldAutoFill(
                        codeLength: 6,
                        decoration: UnderlineDecoration(
                          textStyle: const TextStyle(color: Colors.white, fontSize: 20),
                          colorBuilder: FixedColorBuilder(Colors.white30),
                        ),
                        currentCode: _getOtp(),
                        onCodeChanged: (code) {
                          if (code != null && code.length == 6 && !_isVerifying) {
                            for (int i = 0; i < 6; i++) {
                              _controllers[i].text = code[i];
                            }
                            _verifyOtp();
                          }
                        },
                      )
                    ),
                  ),

                  const SizedBox(height: 24),


                  Text(
                    _timerSeconds > 0
                        ? "Resend OTP in $_timerSeconds seconds"
                        : "Didn't receive the code?",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  if (_timerSeconds == 0)
                    TextButton(
                      onPressed: _resendOtp,
                      child: const Text(
                        "Resend OTP",
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                  const SizedBox(height: 30),


                  AnimatedBuilder(
                    animation: _buttonController,
                    builder: (context, _) {
                      return Opacity(
                        opacity: _buttonOpacity.value,
                        child: Transform.scale(
                          scale: _buttonScale.value,
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isVerifying ? null : _verifyOtp,
                              style: ElevatedButton.styleFrom(
                                padding:
                                const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: Colors.blueAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 8,
                                shadowColor:
                                Colors.blueAccent.withOpacity(0.35),
                              ),
                              child: _isVerifying
                                  ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                                  : const Text(
                                "Verify",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OtpSuccessScreen extends StatelessWidget {
  const _OtpSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A2F),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.greenAccent.withOpacity(0.15),
                border: Border.all(
                  color: Colors.greenAccent.shade200,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.check_rounded,
                color: Colors.greenAccent.shade200,
                size: 50,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "OTP Verified!",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "You're securely signed in to Aura.",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
