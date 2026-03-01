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

  void _showError(String message) {
    AppSnackbar.showError(context: context, message: message);
  }

  Future<void> _handleForgot() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showError('Please enter your email');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AuthRemoteDataSource().forgotPassword(email);
      if (mounted) {
        AppSnackbar.showSuccess(
          context: context,
          message: 'Password reset OTP sent to $email',
        );
        Navigator.pushNamed(context, AppRoutes.resetPassword, arguments: email);
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
    );
  }
}
