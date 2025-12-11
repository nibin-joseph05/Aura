class AppConstants {
  static const String appName = 'Aura';
  static const String appVersion = '1.0.0';

  static const Duration apiTimeout = Duration(seconds: 30);

  static const String userBoxName = 'user_box';
  static const String settingsBoxName = 'settings_box';

  static const Duration shortAnimation = Duration(milliseconds: 300);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 1000);

  static const int otpLength = 6;
  static const Duration otpResendDelay = Duration(seconds: 30);
  static const Duration otpTimeout = Duration(seconds: 60);
}
