import 'package:flutter/material.dart';

import '../../../../../core/routes/app_routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/ui/responsive/responsive.dart';
import '../../../../../core/widgets/navigation/app_header.dart';
import '../../../../../core/widgets/wrappers/confirm_exit_wrapper.dart';
import '../../../../../core/widgets/buttons/primary_button.dart';

class ProfileCompleteScreen extends StatelessWidget {
  const ProfileCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);

    return ConfirmExitWrapper(
      title: "Exit profile setup?",
      message:
          "If you leave now, your profile setup will be cancelled. You can complete it later.",
      confirmText: "Exit",
      cancelText: "Continue",
      onExit: () async {
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushNamedAndRemoveUntil(AppRoutes.welcome, (_) => false);
      },
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
                const AppHeader(
                  title: "Complete Your Profile",
                  textColor: Colors.white,
                  showBack: false,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: responsive.horizontal(7),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: responsive.h(3)),

                          Text(
                            "Tell us a bit about yourself",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: responsive.isTablet ? 24 : 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: responsive.h(1)),

                          const Text(
                            "This helps us personalize your experience.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),

                          SizedBox(height: responsive.h(4)),

                          SizedBox(height: responsive.h(4)),

                          PrimaryButton(
                            label: "Continue",
                            onPressed: () {},
                            responsive: responsive,
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
}
