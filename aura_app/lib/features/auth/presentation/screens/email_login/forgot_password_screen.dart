import 'package:flutter/material.dart';

import '../../../../../core/routes/app_routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/ui/responsive/responsive.dart';
import '../../../../../core/ui/snackbar/app_snackbar.dart';
import '../../../../../core/widgets/buttons/primary_button.dart';
import '../../../../../core/widgets/inputs/app_text_field.dart';
import '../../../../../core/widgets/navigation/app_header.dart';
import '../../../data/datasources/auth_remote_datasource.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String? _emailError;

  void _validateEmail(String value) {
    setState(() {
      if (value.isEmpty) {
        _emailError = 'Please enter your email';
      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
        _emailError = 'Please enter a valid email address';
      } else {
        _emailError = null;
      }
    });
  }

  void _showError(String message) {
    AppSnackbar.showError(context: context, message: message);
  }

  Future<bool> _showUnverifiedDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E2A),
            title: const Text(
              'Email Not Verified',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Your email address is not verified. Are you sure you want to send the password reset code to this email?',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white38),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Send Anyway',
                  style: TextStyle(color: AppColors.accent),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _handleForgot({bool force = false}) async {
    final email = _emailController.text.trim();

    _validateEmail(email);
    if (_emailError != null) {
      return;
    }

    setState(() {
      _isLoading = true;
      _emailError = null;
    });

    try {
      await AuthRemoteDataSource().forgotPassword(email, force: force);
      if (mounted) {
        AppSnackbar.showSuccess(
          context: context,
          message: 'Password reset OTP sent to $email',
        );
        Navigator.pushNamed(context, AppRoutes.resetPassword, arguments: email);
      }
    } catch (e) {
      String errorMessage = e.toString();

      if (errorMessage.contains('unverified_email')) {
        if (mounted) setState(() => _isLoading = false);
        final proceed = await _showUnverifiedDialog();
        if (proceed) {
          _handleForgot(force: true);
        }
        return;
      }

      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }

      if (errorMessage.toLowerCase().contains("no account found") ||
          errorMessage.toLowerCase().contains("email")) {
        setState(() => _emailError = errorMessage);
      } else {
        _showError(errorMessage);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
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
                  title: "Forgot Password",
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
                              Icons.lock_reset,
                              size: responsive.h(12),
                              color: AppColors.textLight,
                            ),
                            SizedBox(height: responsive.h(4)),
                            Text(
                              "Reset Password",
                              style: TextStyle(
                                color: AppColors.textLight,
                                fontSize: titleSize,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            SizedBox(height: responsive.h(2)),
                            Text(
                              "Enter the email associated with your account to receive a one-time password.",
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
                              controller: _emailController,
                              responsive: responsive,
                              hint: "Email address",
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              errorText: _emailError,
                              onChanged: _validateEmail,
                            ),
                            SizedBox(height: responsive.h(4)),
                            _isLoading
                                ? const CircularProgressIndicator(
                                    color: AppColors.primary,
                                  )
                                : PrimaryButton(
                                    label: "Send OTP",
                                    onPressed: _handleForgot,
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
