import 'package:flutter/material.dart';
import '../../../services/auth/firebase_auth_service.dart';
import '../../../services/auth/otp_service.dart';
// import '../profile_setup/profile_setup_screen.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with TickerProviderStateMixin {
  final List<TextEditingController> _controllers =
  List.generate(6, (index) => TextEditingController());

  final List<FocusNode> _focusNodes =
  List.generate(6, (index) => FocusNode());

  bool _isVerifying = false;
  int _timerSeconds = 60;

  late AnimationController _titleController;
  late AnimationController _inputController;
  late AnimationController _buttonController;

  late Animation<Offset> _titleSlide;
  late Animation<double> _titleOpacity;
  late Animation<Offset> _inputSlide;
  late Animation<double> _inputOpacity;
  late Animation<double> _buttonScale;
  late Animation<double> _buttonOpacity;

  @override
  void initState() {
    super.initState();

    _titleController = AnimationController(
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

    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _titleController,
        curve: Curves.easeOutCubic,
      ),
    );

    _titleOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeIn),
    );

    _inputSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _inputController,
        curve: Curves.easeOutCubic,
      ),
    );

    _inputOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: _inputController, curve: Curves.easeIn),
    );

    _buttonScale = Tween<double>(begin: 0.8, end: 1.0)
        .animate(CurvedAnimation(parent: _buttonController, curve: Curves.easeOutBack));

    _buttonOpacity = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _buttonController, curve: Curves.easeIn));

    _startAnimations();
    _startTimer();
  }

  void _startAnimations() {
    _titleController.forward();
    Future.delayed(const Duration(milliseconds: 250), () {
      _inputController.forward();
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      _buttonController.forward();
    });
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (_timerSeconds == 0) return false;

      setState(() {
        _timerSeconds--;
      });

      return true;
    });
  }

  String _getOtp() {
    return _controllers.map((c) => c.text).join();
  }

  Future<void> _verifyOtp() async {
    String otp = _getOtp();

    if (otp.length != 6) {
      _showError("Enter valid 6-digit OTP");
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final user = await FirebaseAuthService().verifyOtp(
        verificationId: OtpService.verificationId!,
        otp: otp,
      );

      if (user == null) {
        _showError("Invalid OTP");
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
      _showError(e.toString());
      setState(() => _isVerifying = false);
    }
  }

  Future<void> _resendOtp() async {
    if (_timerSeconds != 0) return;

    setState(() => _timerSeconds = 60);

    _startTimer();

    _showError("OTP resent!");
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red.shade600,
        content: Text(msg),
      ),
    );
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
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            if (index < 5) {
              _focusNodes[index + 1].requestFocus();
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0A1A2F),
              Color(0xFF134B73),
            ],
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

                SlideTransition(
                  position: _titleSlide,
                  child: FadeTransition(
                    opacity: _titleOpacity,
                    child: const Text(
                      "Verify OTP",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  "Enter the 6-digit code sent to your phone",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),

                const SizedBox(height: 30),

                SlideTransition(
                  position: _inputSlide,
                  child: FadeTransition(
                    opacity: _inputOpacity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (i) => _otpBox(i)),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                Text(
                  _timerSeconds > 0
                      ? "Resend in $_timerSeconds seconds"
                      : "Didn't receive code?",
                  style: const TextStyle(color: Colors.white70),
                ),

                if (_timerSeconds == 0)
                  TextButton(
                    onPressed: _resendOtp,
                    child: const Text(
                      "Resend OTP",
                      style: TextStyle(color: Colors.blueAccent, fontSize: 16),
                    ),
                  ),

                const SizedBox(height: 40),

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
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: _isVerifying
                                ? const CircularProgressIndicator(color: Colors.white)
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
              ],
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
        child: Text(
          "OTP Verified Successfully!",
          style: TextStyle(
            color: Colors.greenAccent.shade200,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
