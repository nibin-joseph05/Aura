import 'package:flutter/material.dart';

import '../../features/auth/presentation/screens/otp/otp_screen.dart';
import '../../features/legal/presentation/screens/privacy_policy/privacy_policy.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/onboarding/presentation/screens/welcome_screen.dart';
import '../../features/auth/presentation/screens/auth_screen/auth_screen.dart';
import '../../features/auth/presentation/screens/phone_login/phone_login_screen.dart';
import '../../features/auth/presentation/screens/success/success_screen.dart';

import 'app_routes.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _build(const SplashScreen());
      case AppRoutes.welcome:
        return _build(const WelcomeScreen());
      case AppRoutes.auth:
        return _build(const AuthScreen());
      case AppRoutes.phoneLogin:
        return _build(const PhoneLoginScreen());
      case AppRoutes.otp:
        final phoneNumber = settings.arguments as String;
        return _build(OtpScreen(phoneNumber: phoneNumber));

      case AppRoutes.otpSuccess:
        return _build(const OtpSuccessScreen());
      case AppRoutes.privacyPolicy:
        return _build(const PrivacyPolicyScreen());
      default:
        return _build(
          const Scaffold(body: Center(child: Text("Route not found"))),
        );
    }
  }

  static MaterialPageRoute _build(Widget child) {
    return MaterialPageRoute(builder: (_) => child);
  }
}
