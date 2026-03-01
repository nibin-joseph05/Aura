import 'package:aura_app/features/home/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';

import '../../features/auth/domain/models/auth_success_payload.dart';
import '../../features/auth/presentation/screens/otp/otp_screen.dart';
import '../../features/auth/presentation/screens/email_login/email_login_screen.dart';
import '../../features/auth/presentation/screens/email_login/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/email_login/reset_password_screen.dart';
import '../../features/user/presentation/screens/profile_complete/profile_complete_screen.dart';
import '../../features/user/presentation/screens/edit_profile_screen.dart';
import '../../features/user/presentation/screens/user_profile_screen.dart';
import '../../features/user/presentation/screens/follow_list_screen.dart';
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
import '../../features/alarm/presentation/screens/alarm_list_screen.dart';
import '../../features/alarm/presentation/screens/create_alarm_screen.dart';
import '../../features/alarm/presentation/screens/alarm_ring_screen.dart';
import '../../features/user/presentation/screens/permissions_screen.dart';
import '../../features/messaging/presentation/screens/chat_list_screen.dart';
import '../../features/messaging/presentation/screens/chat_screen.dart';
import '../../features/messaging/presentation/screens/follow_requests_screen.dart';
import '../../features/notification/presentation/screens/notification_screen.dart';
import '../../features/sos/live/live_location_screen.dart';
import '../../features/home/presentation/screens/change_password_screen.dart';
import '../../features/home/presentation/screens/change_phone_screen.dart';
import '../../features/home/presentation/screens/my_account_screen.dart';
import '../../features/home/presentation/screens/notification_settings_screen.dart';

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
      case AppRoutes.forgotPassword:
        return _build(const ForgotPasswordScreen(), settings);
      case AppRoutes.resetPassword:
        final email = settings.arguments as String;
        return _build(ResetPasswordScreen(email: email), settings);
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
      case AppRoutes.alarmList:
        return _build(const AlarmListScreen(), settings);
      case AppRoutes.alarmCreate:
        return _build(const CreateAlarmScreen(), settings);
      case AppRoutes.alarmEdit:
        final alarmId = settings.arguments as String;
        return _build(CreateAlarmScreen(editAlarmId: alarmId), settings);
      case AppRoutes.alarmRing:
        final alarmId = settings.arguments as String;
        return _build(AlarmRingScreen(alarmId: alarmId), settings);
      case AppRoutes.permissions:
        return _build(const PermissionsScreen(), settings);
      case AppRoutes.chatList:
        return _build(const ChatListScreen(), settings);
      case AppRoutes.chatScreen:
        final args = settings.arguments as Map<String, dynamic>;
        return _build(
          ChatScreen(
            conversationId: args['conversationId'] as String,
            otherUserId: args['otherUserId'] as String,
            otherUserName: args['otherUserName'] as String? ?? '',
          ),
          settings,
        );
      case AppRoutes.followRequests:
        return _build(const FollowRequestsScreen(), settings);
      case AppRoutes.notifications:
        return _build(const NotificationScreen(), settings);
      case AppRoutes.userProfile:
        final userId = settings.arguments as String;
        return _build(UserProfileScreen(userId: userId), settings);
      case AppRoutes.followers:
        final userId = settings.arguments as String;
        return _build(
          FollowListScreen(userId: userId, isFollowers: true),
          settings,
        );
      case AppRoutes.following:
        final userId = settings.arguments as String;
        return _build(
          FollowListScreen(userId: userId, isFollowers: false),
          settings,
        );
      case AppRoutes.liveLocation:
        return _build(const LiveLocationScreen(), settings);
      case AppRoutes.changePassword:
        return _build(const ChangePasswordScreen(), settings);
      case AppRoutes.changePhone:
        return _build(const ChangePhoneScreen(), settings);
      case AppRoutes.notificationSettings:
        return _build(const NotificationSettingsScreen(), settings);
      case AppRoutes.myAccount:
        return _build(const MyAccountScreen(), settings);
      default:
        return _build(
          const Scaffold(body: Center(child: Text("Route not found"))),
          settings,
        );
    }
  }

  static PageRouteBuilder<dynamic> _build(
    Widget child,
    RouteSettings settings,
  ) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOutCubic;
        final tween = Tween(
          begin: const Offset(0.08, 0),
          end: Offset.zero,
        ).chain(CurveTween(curve: curve));
        final fadeTween = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 250),
    );
  }
}
