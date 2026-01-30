import 'package:aura_app/features/home/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';

import '../../features/auth/domain/models/auth_success_payload.dart';
import '../../features/auth/presentation/screens/otp/otp_screen.dart';
import '../../features/auth/presentation/screens/email_login/email_login_screen.dart';
import '../../features/user/presentation/screens/profile_complete/profile_complete_screen.dart';
import '../../features/user/presentation/screens/edit_profile_screen.dart';
import '../../features/common/presentation/screens/success/success_screen.dart';
import '../../features/legal/presentation/screens/privacy_policy/privacy_policy.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/onboarding/presentation/screens/welcome_screen.dart';
import '../../features/auth/presentation/screens/auth_screen/auth_screen.dart';
import '../../features/auth/presentation/screens/phone_login/phone_login_screen.dart';
import '../../features/sos/presentation/screens/sos_trigger_screen.dart';
import '../../features/sos/presentation/screens/sos_settings_screen.dart';
import '../../features/wellness/presentation/screens/wellness_feed_screen.dart';
import '../../features/wellness/presentation/screens/create_wellness_update_screen.dart';
import '../../features/home/presentation/screens/help_faq_screen.dart';
import '../../features/home/presentation/screens/about_screen.dart';
import '../../features/walking/presentation/screens/walking_screen.dart';

import 'app_routes.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _build(const SplashScreen(), settings);
      case AppRoutes.welcome:
        return _build(const WelcomeScreen(), settings);
      case AppRoutes.auth:
        return _build(const AuthScreen(), settings);
      case AppRoutes.phoneLogin:
        return _build(const PhoneLoginScreen(), settings);
      case AppRoutes.emailLogin:
        return _build(const EmailLoginScreen(), settings);
      case AppRoutes.otp:
        final phoneNumber = settings.arguments as String;
        return _build(OtpScreen(phoneNumber: phoneNumber), settings);
      case AppRoutes.otpSuccess:
        final payload = settings.arguments as AuthSuccessPayload;
        return _build(SuccessScreen(payload: payload), settings);
      case AppRoutes.privacyPolicy:
        return _build(const PrivacyPolicyScreen(), settings);
      case AppRoutes.profileComplete:
        return _build(const ProfileCompleteScreen(), settings);
      case AppRoutes.home:
        return _build(const HomeScreen(), settings);
      case AppRoutes.sosTrigger:
        return _build(const SOSTriggerScreen(), settings);
      case AppRoutes.sosSettings:
        return _build(const SOSSettingsScreen(), settings);
      case AppRoutes.wellnessFeed:
        return _build(const WellnessFeedScreen(), settings);
      case AppRoutes.wellnessCreate:
        return _build(const CreateWellnessUpdateScreen(), settings);
      case AppRoutes.editProfile:
        return _build(const EditProfileScreen(), settings);
      case AppRoutes.helpFaq:
        return _build(const HelpFaqScreen(), settings);
      case AppRoutes.about:
        return _build(const AboutScreen(), settings);
      case AppRoutes.walking:
        return _build(const WalkingScreen(), settings);
      default:
        return _build(
          const Scaffold(body: Center(child: Text("Route not found"))),
          settings,
        );
    }
  }

  static MaterialPageRoute _build(Widget child, RouteSettings settings) {
    return MaterialPageRoute(builder: (_) => child, settings: settings);
  }
}
