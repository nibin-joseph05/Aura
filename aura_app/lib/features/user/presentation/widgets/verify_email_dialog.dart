import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/responsive/responsive.dart';
import '../../../../core/widgets/inputs/otp_input_field.dart';
import '../../data/datasources/email_verification_service.dart';
import '../providers/user_provider.dart';

class VerifyEmailDialog extends ConsumerStatefulWidget {
  final String email;

  const VerifyEmailDialog({super.key, required this.email});

  static Future<bool> show(BuildContext context, String email) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => VerifyEmailDialog(email: email),
    );
    return result == true;
  }

  @override
  ConsumerState<VerifyEmailDialog> createState() => _VerifyEmailDialogState();
}

class _VerifyEmailDialogState extends ConsumerState<VerifyEmailDialog> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final _service = EmailVerificationService();

  bool _otpSent = false;
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  int _resendSeconds = 0;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _sendOtp();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() => _resendSeconds = 60);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _resendSeconds--;
        if (_resendSeconds <= 0) t.cancel();
      });
    });
  }

  Future<void> _sendOtp() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });
    try {
      await _service.sendOtp(widget.email);
      if (!mounted) return;
      setState(() {
        _otpSent = true;
        _isLoading = false;
      });
      _startResendTimer();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  String get _fullOtp => _controllers.map((c) => c.text).join();

  void _handleChange(int index, String value) {
    setState(() {
      _hasError = false;
      _errorMessage = null;
    });
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    if (_fullOtp.length == 6) {
      _verifyOtp();
    }
  }

  Future<void> _verifyOtp() async {
    if (_fullOtp.length != 6) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Please enter the complete 6-digit OTP';
      });
      return;
    }

    setState(() => _isLoading = true);
    try {
      final updatedUser = await _service.confirmOtp(widget.email, _fullOtp);
      if (!mounted) return;
      await ref.read(userProvider.notifier).setUser(updatedUser);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
      for (final c in _controllers) {
        c.clear();
      }
      _focusNodes.first.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final brightness = Theme.of(context).brightness;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        color: brightness == Brightness.dark
            ? const Color(0xFF1A1A2E)
            : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: responsive.w(6),
            vertical: responsive.h(3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.containerBorder(brightness),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: responsive.h(2.5)),
              const Icon(
                Icons.email_outlined,
                color: AppColors.accent,
                size: 40,
              ),
              SizedBox(height: responsive.h(1.5)),
              Text(
                'Verify Email',
                style: TextStyle(
                  color: AppColors.onSurface(brightness),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: responsive.h(0.8)),
              Text(
                'A 6-digit code has been sent to\n${widget.email}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.onSurfaceMuted(brightness),
                  fontSize: 13,
                ),
              ),
              SizedBox(height: responsive.h(3)),
              if (_isLoading && !_otpSent)
                const CircularProgressIndicator(color: AppColors.accent)
              else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    6,
                    (i) => OtpInputField(
                      controller: _controllers[i],
                      focusNode: _focusNodes[i],
                      index: i,
                      onChanged: (v) => _handleChange(i, v),
                      responsive: responsive,
                      hasError: _hasError,
                    ),
                  ),
                ),
                if (_errorMessage != null) ...[
                  SizedBox(height: responsive.h(1)),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                SizedBox(height: responsive.h(2.5)),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: responsive.h(1.8),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Verify',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: responsive.h(1.5)),
                TextButton(
                  onPressed: _resendSeconds > 0 ? null : _sendOtp,
                  child: Text(
                    _resendSeconds > 0
                        ? 'Resend OTP in ${_resendSeconds}s'
                        : 'Resend OTP',
                    style: TextStyle(
                      color: _resendSeconds > 0
                          ? AppColors.onSurfaceFaint(brightness)
                          : AppColors.accent,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
