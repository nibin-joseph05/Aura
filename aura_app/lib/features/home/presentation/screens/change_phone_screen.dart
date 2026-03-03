import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/responsive/responsive.dart';
import '../../../../core/widgets/navigation/app_header.dart';
import '../../../user/presentation/providers/user_provider.dart';

class ChangePhoneScreen extends ConsumerStatefulWidget {
  const ChangePhoneScreen({super.key});

  @override
  ConsumerState<ChangePhoneScreen> createState() => _ChangePhoneScreenState();
}

class _ChangePhoneScreenState extends ConsumerState<ChangePhoneScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _otpSent = false;
  String? _verificationId;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider).user;
    if (user?.phone != null) {
      _phoneController.text = user!.phone!;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    final phone = _phoneController.text.trim();
    final formattedPhone = phone.startsWith('+') ? phone : '+91$phone';

    final currentPhone = ref.read(userProvider).user?.phone ?? '';
    final currentFormatted = currentPhone.startsWith('+')
        ? currentPhone
        : '+91$currentPhone';
    if (formattedPhone == currentFormatted) {
      _showError('This is already your current phone number');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _linkPhone(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          _showError(e.message ?? 'Verification failed');
          setState(() => _isLoading = false);
        },
        codeSent: (String vId, int? resendToken) {
          setState(() {
            _verificationId = vId;
            _otpSent = true;
            _isLoading = false;
          });
        },
        codeAutoRetrievalTimeout: (String vId) {
          _verificationId = vId;
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      _showError('Failed to send OTP');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.length != 6) {
      _showError('Enter a valid 6-digit OTP');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _otpController.text,
      );
      await _linkPhone(credential);
    } catch (e) {
      _showError('Invalid OTP');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _linkPhone(PhoneAuthCredential credential) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showError('Not authenticated');
        return;
      }

      await user.updatePhoneNumber(credential);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Phone number updated successfully'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Failed to update phone number');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final brightness = Theme.of(context).brightness;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.backgroundGradient(brightness),
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const AppHeader(title: 'Change Phone', showBack: true),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: responsive.horizontal(5),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: responsive.h(3)),
                          Container(
                            padding: EdgeInsets.all(responsive.w(5)),
                            decoration: BoxDecoration(
                              color: AppColors.containerFill(brightness),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.containerBorder(brightness),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _otpSent
                                      ? 'Verify OTP'
                                      : 'Update Phone Number',
                                  style: TextStyle(
                                    color: AppColors.onSurface(brightness),
                                    fontSize: responsive.isTablet ? 20 : 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: responsive.h(0.5)),
                                Text(
                                  _otpSent
                                      ? 'Enter the 6-digit code sent to your phone'
                                      : 'Enter your new phone number with country code',
                                  style: TextStyle(
                                    color: AppColors.onSurfaceMuted(brightness),
                                    fontSize: responsive.isTablet ? 13 : 12,
                                  ),
                                ),
                                SizedBox(height: responsive.h(3)),
                                if (!_otpSent) ...[
                                  TextFormField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    style: TextStyle(
                                      color: AppColors.onSurface(brightness),
                                      fontSize: 16,
                                    ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9+]'),
                                      ),
                                      LengthLimitingTextInputFormatter(15),
                                    ],
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) {
                                        return 'Enter phone number';
                                      }
                                      final digits = v.replaceAll(
                                        RegExp(r'[^0-9]'),
                                        '',
                                      );
                                      if (digits.length < 10) {
                                        return 'Enter a valid phone number';
                                      }
                                      return null;
                                    },
                                    decoration: _inputDecoration(
                                      'Phone Number',
                                      Icons.phone_outlined,
                                    ),
                                  ),
                                ],
                                if (_otpSent) ...[
                                  TextFormField(
                                    controller: _otpController,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                      color: AppColors.onSurface(brightness),
                                      fontSize: 24,
                                      letterSpacing: 8,
                                    ),
                                    textAlign: TextAlign.center,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(6),
                                    ],
                                    decoration: _inputDecoration(
                                      'OTP Code',
                                      Icons.lock_outlined,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          SizedBox(height: responsive.h(3)),
                          ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : (_otpSent ? _verifyOtp : _sendOtp),
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
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    _otpSent ? 'Verify & Update' : 'Send OTP',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                          if (_otpSent) ...[
                            SizedBox(height: responsive.h(2)),
                            TextButton(
                              onPressed: _isLoading
                                  ? null
                                  : () => setState(() {
                                      _otpSent = false;
                                      _otpController.clear();
                                    }),
                              child: const Text(
                                'Change number',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                          ],
                          SizedBox(height: responsive.h(3)),
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

  InputDecoration _inputDecoration(String label, IconData icon) {
    final brightness = Theme.of(context).brightness;
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: AppColors.onSurfaceMuted(brightness)),
      prefixIcon: Icon(
        icon,
        color: AppColors.onSurfaceFaint(brightness),
        size: 20,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.inputBorder(brightness)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.accent),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      errorStyle: const TextStyle(color: AppColors.error),
      filled: true,
      fillColor: AppColors.inputFill(brightness),
    );
  }
}
