import 'package:flutter/material.dart';

import '../../../../../core/routes/app_routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/ui/responsive/responsive.dart';
import '../../../../../core/ui/snackbar/app_snackbar.dart';
import '../../../../../core/widgets/buttons/primary_button.dart';
import '../../../../../core/widgets/inputs/app_text_field.dart';
import '../../../../../core/widgets/navigation/app_header.dart';
import '../../../data/datasources/auth_remote_datasource.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  String? _otpError;
  String? _passwordError;
  String? _confirmError;

  void _validateOtp(String value) {
    setState(() {
      if (value.isEmpty) {
        _otpError = 'OTP is required';
      } else if (value.length != 6) {
        _otpError = 'OTP must be exactly 6 digits';
      } else {
        _otpError = null;
      }
    });
  }

  void _validatePassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _passwordError = 'Password is required';
      } else if (value.length < 8) {
        _passwordError = 'Password must be at least 8 characters';
      } else if (!RegExp(r'[A-Z]').hasMatch(value)) {
        _passwordError = 'Include at least one uppercase letter';
      } else if (!RegExp(r'[a-z]').hasMatch(value)) {
        _passwordError = 'Include at least one lowercase letter';
      } else if (!RegExp(r'[0-9]').hasMatch(value)) {
        _passwordError = 'Include at least one number';
      } else if (!RegExp(r'[!@#\$%\^&\*(),.?":{}|<>]').hasMatch(value)) {
        _passwordError = 'Include at least one special character';
      } else {
        _passwordError = null;
      }

      if (_confirmController.text.isNotEmpty) {
        _validateConfirm(_confirmController.text);
      }
    });
  }

  void _validateConfirm(String value) {
    setState(() {
      if (value.isEmpty) {
        _confirmError = 'Confirm your password';
      } else if (value != _passwordController.text) {
        _confirmError = 'Passwords do not match';
      } else {
        _confirmError = null;
      }
    });
  }

  void _showError(String message) {
    AppSnackbar.showError(context: context, message: message);
  }

  Future<void> _handleReset() async {
    final otp = _otpController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    _validateOtp(otp);
    _validatePassword(password);
    _validateConfirm(confirm);

    if (_otpError != null || _passwordError != null || _confirmError != null) {
      _showError('Please fix the errors before proceeding');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AuthRemoteDataSource().resetPassword(
        email: widget.email,
        otp: otp,
        newPassword: password,
      );
      if (mounted) {
        AppSnackbar.showSuccess(
          context: context,
          message: 'Password reset successfully. You can now login.',
        );
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.emailLogin,
          (route) => false,
        );
      }
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
      _showError(errorMessage);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
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

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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
                const AppHeader(
                  title: "Reset Password",
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
                            Icon(
                              Icons.password,
                              size: responsive.h(10),
                              color: AppColors.textLight,
                            ),
                            SizedBox(height: responsive.h(4)),
                            Text(
                              "Create New Password",
                              style: TextStyle(
                                color: AppColors.textLight,
                                fontSize: titleSize,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            SizedBox(height: responsive.h(2)),
                            Text(
                              "Enter the OTP sent to ${widget.email} and your new password.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textLight.withValues(
                                  alpha: 0.75,
                                ),
                                fontSize: subtitleSize,
                                height: 1.4,
                              ),
                            ),
                            SizedBox(height: responsive.h(4)),
                            AppTextField(
                              controller: _otpController,
                              responsive: responsive,
                              hint: "6-Digit OTP",
                              icon: Icons.pin_outlined,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              errorText: _otpError,
                              onChanged: _validateOtp,
                            ),
                            SizedBox(height: responsive.h(2)),
                            AppTextField(
                              controller: _passwordController,
                              responsive: responsive,
                              hint: "New Password",
                              icon: Icons.lock_outline,
                              obscureText: _obscurePassword,
                              errorText: _passwordError,
                              onChanged: _validatePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: AppColors.textLight.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                            ),
                            SizedBox(height: responsive.h(2)),
                            AppTextField(
                              controller: _confirmController,
                              responsive: responsive,
                              hint: "Confirm Password",
                              icon: Icons.lock_outline,
                              obscureText: _obscureConfirm,
                              errorText: _confirmError,
                              onChanged: _validateConfirm,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirm
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: AppColors.textLight.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                                onPressed: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm,
                                ),
                              ),
                            ),
                            SizedBox(height: responsive.h(4)),
                            _isLoading
                                ? const CircularProgressIndicator(
                                    color: AppColors.primary,
                                  )
                                : PrimaryButton(
                                    label: "Reset Password",
                                    onPressed: _handleReset,
                                    responsive: responsive,
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
      ),
    );
  }
}
