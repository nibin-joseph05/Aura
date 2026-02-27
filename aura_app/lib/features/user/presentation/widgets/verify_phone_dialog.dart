import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/responsive/responsive.dart';
import '../../../../core/widgets/inputs/otp_input_field.dart';
import '../../data/datasources/user_remote_datasource.dart';
import '../providers/user_provider.dart';
import '../../../../features/auth/data/datasources/firebase_auth_datasource.dart';

class VerifyPhoneDialog extends ConsumerStatefulWidget {
  final String phone;

  const VerifyPhoneDialog({super.key, required this.phone});

  static Future<bool> show(BuildContext context, String phone) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => VerifyPhoneDialog(phone: phone),
    );
    return result == true;
  }

  @override
  ConsumerState<VerifyPhoneDialog> createState() => _VerifyPhoneDialogState();
}

class _VerifyPhoneDialogState extends ConsumerState<VerifyPhoneDialog> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final _firebaseAuth = FirebaseAuthDataSource();

  String? _verificationId;
  int? _resendToken;
  bool _codeSent = false;
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

  Future<void> _sendOtp({bool resend = false}) async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    await _firebaseAuth.sendOtp(
      phoneNumber: widget.phone,
      forceResendToken: resend ? _resendToken : null,
      onCodeSent: (verificationId, resendToken) {
        if (!mounted) return;
        setState(() {
          _verificationId = verificationId;
          _resendToken = resendToken;
          _codeSent = true;
          _isLoading = false;
        });
        _startResendTimer();
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMessage = error;
        });
      },
      onAutoVerified: (credential) async {
        try {
          await _linkPhoneCredential(credential);
        } catch (_) {}
      },
    );
  }

  Future<void> _linkPhoneCredential(PhoneAuthCredential credential) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      try {
        await currentUser.linkWithCredential(credential);
      } on FirebaseAuthException catch (e) {
        if (e.code != 'provider-already-linked' &&
            e.code != 'credential-already-in-use') {
          rethrow;
        }
      }
    } else {
      final result = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      await result.user?.delete();
      await FirebaseAuth.instance.signOut();
    }

    await _markPhoneVerifiedOnBackend();
  }

  Future<void> _markPhoneVerifiedOnBackend() async {
    final backendUser = ref.read(userProvider).user;
    if (backendUser == null) {
      if (mounted) Navigator.pop(context, true);
      return;
    }
    final updated = await UserRemoteDataSource().updateProfile(
      uid: backendUser.uid,
      phone: widget.phone,
      phoneVerified: true,
    );
    if (!mounted) return;
    await ref.read(userProvider.notifier).setUser(updated);
    if (!mounted) return;
    Navigator.pop(context, true);
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
    if (_verificationId == null || _fullOtp.length != 6) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Please enter the complete 6-digit OTP';
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _fullOtp,
      );
      await _linkPhoneCredential(credential);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.code == 'invalid-verification-code'
            ? 'Invalid OTP. Please try again'
            : (e.message ?? 'Verification failed');
      });
      for (final c in _controllers) {
        c.clear();
      }
      _focusNodes.first.requestFocus();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: responsive.h(2.5)),
              const Icon(
                Icons.phone_outlined,
                color: AppColors.accent,
                size: 40,
              ),
              SizedBox(height: responsive.h(1.5)),
              const Text(
                'Verify Phone',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: responsive.h(0.8)),
              Text(
                'A 6-digit OTP has been sent to\n${widget.phone}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              SizedBox(height: responsive.h(3)),
              if (_isLoading && !_codeSent)
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
                  onPressed: _resendSeconds > 0
                      ? null
                      : () => _sendOtp(resend: true),
                  child: Text(
                    _resendSeconds > 0
                        ? 'Resend OTP in ${_resendSeconds}s'
                        : 'Resend OTP',
                    style: TextStyle(
                      color: _resendSeconds > 0
                          ? Colors.white38
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
