import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/responsive/responsive.dart';
import '../../../../core/widgets/navigation/app_header.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../auth/data/datasources/auth_remote_datasource.dart';
import '../../../user/presentation/providers/user_provider.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final user = ref.read(userProvider).user;
      if (user == null) throw Exception('User not found');

      await AuthRemoteDataSource().changePassword(
        uid: user.uid,
        currentPassword: _currentController.text,
        newPassword: _newController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Password changed successfully'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.pop(context);
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

  Future<void> _sendPasswordResetEmail() async {
    final email = ref.read(userProvider).user?.email;
    if (email == null || email.isEmpty) {
      _showError('No email associated with this account');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AuthRemoteDataSource().forgotPassword(email);
      if (mounted) {
        Navigator.pop(context);
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
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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
                const AppHeader(title: 'Change Password', showBack: true),
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
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.12),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Update Password',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: responsive.isTablet ? 20 : 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: responsive.h(0.5)),
                                Text(
                                  'Enter your current password and choose a new one',
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: responsive.isTablet ? 13 : 12,
                                  ),
                                ),
                                SizedBox(height: responsive.h(3)),
                                _buildPasswordField(
                                  controller: _currentController,
                                  label: 'Current Password',
                                  obscure: _obscureCurrent,
                                  onToggle: () => setState(
                                    () => _obscureCurrent = !_obscureCurrent,
                                  ),
                                  responsive: responsive,
                                  validator: (v) {
                                    if (v == null || v.isEmpty)
                                      return 'Enter current password';
                                    return null;
                                  },
                                ),
                                SizedBox(height: responsive.h(2)),
                                _buildPasswordField(
                                  controller: _newController,
                                  label: 'New Password',
                                  obscure: _obscureNew,
                                  onToggle: () => setState(
                                    () => _obscureNew = !_obscureNew,
                                  ),
                                  responsive: responsive,
                                  validator: (v) {
                                    if (v == null || v.isEmpty)
                                      return 'Enter new password';
                                    if (v.length < 8)
                                      return 'Password must be at least 8 characters';
                                    if (!RegExp(r'[A-Z]').hasMatch(v))
                                      return 'Include at least one uppercase letter';
                                    if (!RegExp(r'[a-z]').hasMatch(v))
                                      return 'Include at least one lowercase letter';
                                    if (!RegExp(r'[0-9]').hasMatch(v))
                                      return 'Include at least one number';
                                    if (!RegExp(
                                      r'[!@#\$%\^&\*(),.?":{}|<>]',
                                    ).hasMatch(v))
                                      return 'Include at least one special character';
                                    return null;
                                  },
                                ),
                                SizedBox(height: responsive.h(2)),
                                _buildPasswordField(
                                  controller: _confirmController,
                                  label: 'Confirm New Password',
                                  obscure: _obscureConfirm,
                                  onToggle: () => setState(
                                    () => _obscureConfirm = !_obscureConfirm,
                                  ),
                                  responsive: responsive,
                                  validator: (v) {
                                    if (v != _newController.text)
                                      return 'Passwords do not match';
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: responsive.h(3)),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _changePassword,
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
                                : const Text(
                                    'Change Password',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                          SizedBox(height: responsive.h(2)),
                          TextButton.icon(
                            onPressed: _isLoading
                                ? null
                                : _sendPasswordResetEmail,
                            icon: const Icon(
                              Icons.email_outlined,
                              color: Colors.white70,
                              size: 18,
                            ),
                            label: const Text(
                              'Send password reset email instead',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ),
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    required Responsive responsive,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
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
        fillColor: Colors.white.withValues(alpha: 0.05),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: Colors.white38,
            size: 20,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }
}
